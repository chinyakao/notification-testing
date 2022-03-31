# frozen_string_literal: true

require 'roda'
require 'slim'

module NotificationTesting
  # Web App
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :public, root: 'app/views/public'
    plugin :assets, path: 'app/views/assets',
                    css: 'style.css', js: 'table_row_click.js'
    plugin :halt

    route do |routing|
      routing.assets # load CSS
      routing.public

      # GET /
      routing.root do # rubocop:disable Metrics/BlockLength
        studys = Study.all()
        view 'home', locals: { studys: studys}
      end

      routing.on 'study' do
        routing.on String do |study_id|
          # GET /study/{study_id}
          routing.get do
            # Get project from database
            study = Study.where(id: study_id).first
            participants = Participant.where(owner_study_id: study_id).all
            reminders = Reminder.where(owner_study_id: study_id).all
            
            # Show viewer the project
            view 'study', locals: { study: study, participants: participants, reminders: reminders }
          end
        end
      end

      routing.on 'participant' do
        routing.on String do |participant_id|
          # GET /study/{study_id}
          routing.get do
            # Get project from database
            participant = Participant.where(id: participant_id).first
            study = Study.where(id: participant[:owner_study_id]).first
            
            # Show viewer the project
            view 'participant', locals: { study: study, participant: participant }
          end
        end
      end
    end
  end
end
