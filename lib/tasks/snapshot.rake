desc 'Take a snapshot of in-app communications using the Postmark Messages API'
namespace :snapshot do
  task take: :environment do
    snapshot = Snapshot.take
    snapshot.save

    puts "Snapshot taken at #{Time.now}"
    puts "Nodes: #{snapshot.data['nodes'].count}"
    puts "Links: #{snapshot.data['links'].count}"
  end
end
