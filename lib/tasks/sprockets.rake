namespace :sprockets do
  task benchmark: :environment do
    asset_count = 1500
    puts "Creating #{asset_count} empty assets..."
    asset_count.times { |i| `touch #{Rails.root}/app/assets/images/#{i}.png` }
    puts "Done"

    puts "Precompiling assets..."
    Rake.application.invoke_task "assets:precompile"
    puts "Done"

    puts "Running benchmark..."

    start = Time.now
    count = 1500
    count.times { ActionController::Base.helpers.asset_path('1.png') }
    puts "#{count} lookups of the same asset took #{(Time.now - start) / 1.second}"

    start = Time.now
    count = 1500
    count.times { |i| ActionController::Base.helpers.asset_path("#{i}.png") }
    puts "#{count} lookups of #{count} different assets took #{(Time.now - start) / 1.second}"
  end
end
