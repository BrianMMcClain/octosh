Dir[File.expand_path("../worker/*.rb", __FILE__)].each do |file|
  require file
end