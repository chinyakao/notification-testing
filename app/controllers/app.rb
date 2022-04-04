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

    route do |routing|
      routing.assets # load CSS
      routing.public

      config = App.config

      # GET /
      routing.root do # rubocop:disable Metrics/BlockLength
        studys = GetAllStudies.new.call
        view 'home', locals: { studys: studys }
      end

      routing.on 'study' do
        routing.on String do |study_id|
          # DELETE /study/{study_id}/deletion
          routing.on 'deletion' do
            routing.post do
              action = routing.params['_method']
              DeleteStudy.new(config).call(id: study_id) if action == 'DELETE'
              redirect_route = routing.params['redirect_route']

              # Reroute to study
              routing.redirect redirect_route
            end
          end

          # POST /study/{study_id}/launch
          routing.on 'launch' do
            routing.post do
              LaunchStudy.new(config).call(study_id: study_id)
              redirect_route = routing.params['redirect_route']

              # Reroute to study
              routing.redirect redirect_route
            end
          end

          # POST /study/{study_id}/stop
          routing.on 'stop' do
            routing.post do
              StopStudy.new(config).call(study_id: study_id)
              redirect_route = routing.params['redirect_route']

              # Reroute to study
              routing.redirect redirect_route
            end
          end

          # GET /study/{study_id}
          routing.get do
            # Get study from database
            study = GetStudy.new.call(id: study_id)
            participants = GetAllParticipants.new.call(owner_study_id: study_id)
            reminders = GetAllReminders.new.call(owner_study_id: study_id)
            now_time = Time.new

            # Show viewer the study
            view 'study', locals: { study: study, participants: participants, reminders: reminders, now_time: now_time }
          end
        end

        # POST /study
        routing.post do
          title = routing.params['study_title']
          study = CreateStudy.new(config).call(title: title)

          routing.redirect '/'
        end
      end

      routing.on 'participant' do
        routing.on String do |participant_id|
          # DELETE /participant/{participant_id}/deletion
          routing.on 'deletion' do
            routing.post do
              action = routing.params['_method']
              DeleteParticipant.new(config).call(id: participant_id) if action == 'DELETE'
              redirect_route = routing.params['redirect_route']

              # Reroute to study
              routing.redirect redirect_route
            end
          end

          # GET /participant/{participant_id}
          routing.get do
            # Get participant from database
            participant = GetParticipant.new.call(id: participant_id)
            participant_detail = GetParticipantDetail.new.call(participant: participant)
            study = GetStudy.new.call(id: participant[:owner_study_id])

            # Show viewer the participant
            view 'participant', locals: { study: study, participant: participant, participant_detail: participant_detail }
          end
        end

        # POST /participant
        routing.post do
          # participant = Participant.create(params)
          participant = CreateParticipant.new(config).call(participant: routing.params)

          routing.redirect "/participant/#{participant.id}"
        end
      end

      routing.on 'reminder' do
        routing.on String do |reminder_id|
          # DELETE /reminder/{reminder_id}/deletion
          routing.on 'deletion' do
            routing.post do
              action = routing.params['_method']
              Reminder.where(id: reminder_id).destroy if action == 'DELETE'

              redirect_route = routing.params['redirect_route']

              # Reroute to study
              routing.redirect redirect_route
            end
          end

          # GET /reminder/{reminder_id}
          routing.get do
            # Get reminder from database
            reminder = GetReminder.new.call(id: reminder_id)
            study = GetStudy.new.call(id: reminder[:attributes][:owner_study].id)

            # Show viewer the reminder
            view 'reminder', locals: { study: study, reminder: reminder }
          end
        end

        # POST /reminder
        routing.post do
          params = routing.params
          reminder = CreateReminder.new.call(params: params)

          routing.redirect "/reminder/#{reminder.id}"
        end
      end
    end
  end
end
