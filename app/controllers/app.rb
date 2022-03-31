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
    end
  end
end
