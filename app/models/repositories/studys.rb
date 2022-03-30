# frozen_string_literal: true

require_relative 'participants'
require_relative 'reminders'

module NotificationTesting
  module Repository
    # Repository for Study Entities
    class Studys
      def self.all
        Database::StudyOrm.all.map { |db_study| rebuild_entity(db_study) }
      end

      def self.find(entity)
        find_title(entity.title)
      end

      def self.find_id(id)
        db_record = Database::StudyOrm.first(id: id)
        rebuild_entity(db_record)
      end

      def self.find_title(title)
        db_record = Database::StudyOrm.first(title: title)
        rebuild_entity(db_record)
      end

      def self.create(entity)
        raise 'Study already exists' if find(entity)

        db_study = PersistStudy.new(entity).create_study
        rebuild_entity(db_study)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Study.new(
          id:        db_record.id,
          title:     db_record.title,
          aws_arn:   db_record.aws_arn
        )
      end

      def self.db_find_or_create(entity)
        Database::StudyOrm.find_or_create(entity.to_attr_hash)
      end

      # # Helper class to persist study and its members to database
      # class PersistStudy
      #   def initialize(entity)
      #     @entity = entity
      #   end

      #   def create_study
      #     Database::StudyOrm.create(@entity.to_attr_hash)
      #   end

      #   def call
      #     study = Studys.db_find_or_create(@entity.study)

      #     create_study.tap do |db_study|
      #       db_study.update(study: study)
      #     end
      #   end
      # end
    end
  end
end
