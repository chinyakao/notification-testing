# frozen_string_literal: true

require 'roda'
require 'slim'
require 'json'

module NotificationTesting
  # Web App
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :public, root: 'app/views/public'
    plugin :assets, path: 'app/views/assets',
                    css: 'style.css', js: 'table_row_click.js'

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
            # Get study from database
            study = Study.where(id: study_id).first
            participants = Participant.where(owner_study_id: study_id).all
            reminders = Reminder.where(owner_study_id: study_id).all
            
            # Show viewer the study
            view 'study', locals: { study: study, participants: participants, reminders: reminders }
          end

          # DELETE /study/{study_id}/deletion
          routing.on 'deletion' do
            Study.where(id: study_id).destroy
            redirect_route = routing.params['redirect_route']
            
            # Reroute to study
            routing.redirect redirect_route
          end
        end
      end

      routing.on 'participant' do
        routing.on String do |participant_id|
          # GET /participant/{participant_id}
          routing.get do
            # Get participant from database
            participant = Participant.where(id: participant_id).first
            participant_detail = GetParticipantDetail.new.call(participant: participant)
            study = Study.where(id: participant[:owner_study_id]).first

            # Show viewer the participant
            view 'participant', locals: { study: study, participant: participant, participant_detail: participant_detail }
          end

          # DELETE /participant/{participant_id}/deletion
          routing.on 'deletion' do
            Participant.where(id: participant_id).destroy
            redirect_route = routing.params['redirect_route']
            
            # Reroute to study
            routing.redirect redirect_route
          end
        end
      end

      routing.on 'reminder' do
        routing.on String do |reminder_id|
          # GET /reminder/{reminder_id}
          routing.get do
            # Get reminder from database
            reminder = Reminder.where(id: reminder_id).first
            study = Study.where(id: reminder[:owner_study_id]).first

            # Show viewer the reminder
            view 'reminder', locals: { study: study, reminder: reminder }
          end

          # DELETE /reminder/{reminder_id}/deletion
          routing.on 'deletion' do
            Reminder.where(id: reminder_id).destroy
            redirect_route = routing.params['redirect_route']
            
            # Reroute to study
            routing.redirect redirect_route
          end
        end
      end
    end
  end
end
