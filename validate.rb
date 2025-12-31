#!/usr/bin/env ruby

require 'jekyll'

# Load Jekyll site
config = Jekyll.configuration({})
site = Jekyll::Site.new(config)
site.read

# Group posts by base_slug and lang
groups = Hash.new { |h, k| h[k] = [] }

site.posts.docs.each do |post|
  base_slug = post.data['base_slug']
  lang = post.data['lang']
  if base_slug && lang
    key = "#{base_slug}-#{lang}"
    groups[key] << post
  end
end

# Check for duplicates
errors = []
groups.each do |key, posts|
  if posts.size > 1
    base_slug, lang = key.split('-', 2)
    errors << "Duplicate base_slug '#{base_slug}' for lang '#{lang}': #{posts.map { |p| p.basename }.join(', ')}"
  end
end

if errors.empty?
  puts "Validation passed: No duplicate base_slug for same lang."
  exit 0
else
  puts "Validation failed:"
  errors.each { |e| puts e }
  exit 1
end