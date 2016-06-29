namespace :sprockets do
  task benchmark: :environment do
    remove_assets

    asset_count = 1500
    puts "Creating #{asset_count} empty assets in the same directory..."
    asset_count.times { |i| `touch #{Rails.root}/app/assets/images/#{i}.png` }
    puts "Done"

    if ENV['PRECOMPILE']
      precompile_assets
    end

    puts "Running benchmark..."

    benchmark_single_file_lookup("1.png")
    benchmark_many_file_lookup { |i| "#{i}.png" }
  end

  task benchmark_dirs: :environment do
    remove_assets

    asset_count = 1500
    puts "Creating #{asset_count} empty assets in #{asset_count} directories..."
    asset_count.times do |i|
      dir = "#{Rails.root}/app/assets/images/#{i}"
      `mkdir #{dir} && touch #{dir}/image.png`
    end
    puts "Done"

    if ENV['PRECOMPILE']
      precompile_assets
    end

    puts "Running benchmark..."

    benchmark_single_file_lookup("1/image.png")
    benchmark_many_file_lookup { |i| "#{i}/image.png" }
  end

  def remove_assets
    `rm -rf #{Rails.root}/app/assets/images/* #{Rails.root}/public/assets/`
  end

  def precompile_assets
    puts "Precompiling assets..."
    Rake.application.invoke_task "assets:precompile"
    puts "Done"
  end

  def benchmark_single_file_lookup(file)
    start = Time.now
    count = 1500
    count.times { ActionController::Base.helpers.asset_path(file) }
    puts "#{count} lookups of the same asset took #{(Time.now - start) / 1.second}"
  end

  def benchmark_many_file_lookup
    start = Time.now
    count = 1500
    count.times { |i| ActionController::Base.helpers.asset_path(yield(i)) }
    puts "#{count} lookups of #{count} different assets took #{(Time.now - start) / 1.second}"
  end
end
