require 'mail'
require 'set'

class Snapshot < ApplicationRecord
  serialize :data, coder: JSON

  def self.take
    client = Postmark::ApiClient.new(Rails.application.config.x.postmark.api_token)
    sent_messages = client.get_messages
    nodes_list, links_list = collect_nodes_and_links(sent_messages).values_at(:nodes, :links)

    data = {
      nodes: nodes_list,
      links: links_list
    }

    Snapshot.new(data: data)
  end

  def self.extract_address(address_string)
    Mail::Address.new(address_string).display_name
  end

  private

  def self.collect_nodes_and_links(sent_messages)
    nodes_set = Set.new # efficiently stores unique email addresses
    links_hash = {} # bucket-like, 'sender->recipient' is the key, holds all topics between those two

    sent_messages.each do |message|
      sender = message[:from]
      sender_email = sender.split('<').last.delete('>').strip
      recipients = message[:to]

      nodes_set.add({id: sender_email})

      recipients.each do |recipient|
        recipient_email = recipient['Email']
        nodes_set.add({id: recipient_email})

      sorted_emails = [sender_email, recipient_email].sort # sorting enables storing topics between the same pair of emails regardless of who sent to whom
      link_key = "#{sorted_emails[0]}->#{sorted_emails[1]}"

        if links_hash.key?(link_key)
          links_hash[link_key][:topics].add(message[:subject])
        else
          links_hash[link_key] = {source: sender_email, target: recipient_email, topics: Set.new([message[:subject]])}
        end
      end
    end

    links_set = links_hash.values.map do |link|
      link[:topics] = link[:topics].to_a.join(', ')
      link
    end

    { nodes: nodes_set.to_a, links: links_set }
  end
end
