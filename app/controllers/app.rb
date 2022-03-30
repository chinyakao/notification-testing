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
        studys = Repository::For.klass(Entity::Study).all
        participants = Repository::For.klass(Entity::Participant).all
        reminders = Repository::For.klass(Entity::Reminder).all
        view 'home', locals: { studys: studys,  participants: participants, reminders: reminders}
      end

      routing.on 'study' do
        routing.is do
          # POST /study/
          routing.post do
            study_title = routing.params['study_title']
  
            # Get project from Github
            study = Schedule::StudyMapper.new.find(study_title)

            # Add project to database
            study_entity = Repository::For.entity(study).db_find_or_create(study)
            binding.irb

            # Redirect viewer to project page
            routing.redirect "study/#{study_entity[:id]}"
          end
        end

        routing.on String do |study_id|
          # GET /study/{study_title}
          routing.get do
            # Get project from database
            study = Repository::For.klass(Entity::Study)
              .find_id(study_id)

            # Show viewer the project
            view 'study', locals: { study: study }
          end
        end
      end
    end
  end
end
