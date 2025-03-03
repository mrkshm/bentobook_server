class ConfigurationsController < ApplicationController
  def ios_v1
    render json: {
      settings: {},
      rules: [
        {
          # Default rule for all routes
          patterns: [ ".*" ],
          properties: {
            context: "default",
            presentation: "push",
            pull_to_refresh_enabled: true
          }
        },
        {
          # After sign in, replace root to clear navigation stack
          patterns: [ "^/home/dashboard$" ],
          properties: {
            context: "default",
            presentation: "replace_root",
            pull_to_refresh_enabled: false
          }
        },
        {
          # Forms should be modals
          patterns: [
            "/new$",
            "/edit$",
            "/edit_notes$"
          ],
          properties: {
            context: "modal",
            presentation: "default",
            pull_to_refresh_enabled: false,
            modal_style: "large"
          }
        }
      ]
    }
  end
end
