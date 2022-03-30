# frozen_string_literal: true

require_relative 'studys'

module NotificationTesting
  module Repository
    # Repository for Reminder Entities
    class Reminders
      def self.all
        Database::ReminderOrm.all.map { |db_reminder| rebuild_entity(db_reminder) }
      end

      def self.find_full_name(study_title, reminder_code)
        # SELECT * FROM `reminders` LEFT JOIN `members`
        # ON (`members`.`id` = `reminders`.`study_id`)
        # WHERE ((`username` = 'study_name') AND (`name` = 'reminder_name'))
        db_reminder = Database::ReminderOrm
          .left_join(:studys, id: :study_id)
          .where(title: study_title, code: reminder_code)
          .first
        rebuild_entity(db_reminder)
      end

      def self.find(entity)
        find_code(entity.code)
      end

      def self.find_id(id)
        db_record = Database::ReminderOrm.first(id: id)
        rebuild_entity(db_record)
      end

      def self.find_code(code)
        db_record = Database::ReminderOrm.first(code: code)
        rebuild_entity(db_record)
      end

      def self.create(entity)
        raise 'Reminder already exists' if find(entity)

        db_reminder = PersistReminder.new(entity).call
        rebuild_entity(db_reminder)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Reminder.new(
          db_record.to_hash.merge(
            study: Studys.rebuild_entity(db_record.study)
          )
        )
      end

      # Helper class to persist reminder and its members to database
      class PersistReminder
        def initialize(entity)
          @entity = entity
        end

        def create_reminder
          Database::ReminderOrm.create(@entity.to_attr_hash)
        end

        def call
          study = Studys.db_find_or_create(@entity.study)

          create_reminder.tap do |db_reminder|
            db_reminder.update(study: study)
          end
        end
      end
    end
  end
end
