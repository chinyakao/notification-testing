# frozen_string_literal: true

require_relative 'studys'

module NotificationTesting
  module Repository
    # Repository for Participant Entities
    class Participants
      def self.all
        Database::ParticipantOrm.all.map { |db_participant| rebuild_entity(db_participant) }
      end

      def self.find_full_name(study_title, participant_parameter)
        # SELECT * FROM `participants` LEFT JOIN `members`
        # ON (`members`.`id` = `participants`.`study_id`)
        # WHERE ((`username` = 'study_name') AND (`name` = 'participant_name'))
        db_participant = Database::ParticipantOrm
          .left_join(:studys, id: :study_id)
          .where(title: study_title, parameter: participant_parameter)
          .first
        rebuild_entity(db_participant)
      end

      def self.find(entity)
        find_parameter(entity.parameter)
      end

      def self.find_id(id)
        db_record = Database::ParticipantOrm.first(id: id)
        rebuild_entity(db_record)
      end

      def self.find_parameter(parameter)
        db_record = Database::ParticipantOrm.first(parameter: parameter)
        rebuild_entity(db_record)
      end

      def self.create(entity)
        raise 'Participant already exists' if find(entity)

        db_participant = PersistParticipant.new(entity).call
        rebuild_entity(db_participant)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Participant.new(
          db_record.to_hash.merge(
            study: Studys.rebuild_entity(db_record.study)
          )
        )
      end

      # Helper class to persist participant and its members to database
      class PersistParticipant
        def initialize(entity)
          @entity = entity
        end

        def create_participant
          Database::ParticipantOrm.create(@entity.to_attr_hash)
        end

        def call
          study = Studys.db_find_or_create(@entity.study)

          create_participant.tap do |db_participant|
            db_participant.update(study: study)
          end
        end
      end
    end
  end
end