if Sidekiq.server?
  Sidekiq::Cron::Job.create(
    name: "Cleanup orphaned google restaurants - weekly",
    cron: "0 0 * * 0", # At midnight on Sunday
    class: "CleanupOrphanedGoogleRestaurantsJob"
  )
end
