threads_count = ENV.fetch("RACK_MAX_THREADS") { 1 }
threads threads_count, threads_count
port ENV.fetch("PORT") { 9393 }
environment ENV.fetch("RACK_ENV") { "development" }
log_requests true
