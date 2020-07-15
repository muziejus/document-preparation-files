#!/usr/bin/env ruby
# Based on https://github.com/denten-bin/write-support

require 'slop'
require 'yaml'

opts = Slop.parse do |o|
  o.banner = "usage: pandoc_process [options] [files]\n
    By default, the filelist is built from “file_order“ in the metadata
    Hence, `pandoc_process` by itself is sufficient to create a .pdf.\n"
  o.string '-o', '--outfile', 'outfile', default: "main.pdf"
  o.string '-m', '--metadata-file', 'metadata-file', default: "metadata.yml"
  o.on '-h', '--help', "print this message" do
    puts o
    exit
  end
end

# Load in metadata
metadata = YAML.load_file(opts[:metadata_file])

# Concatenate markdown files using the file_order metadata
metadata["file_order"] ? files = metadata["file_order"].join(" ") : files = opts.arguments.join(" ")

# Add templating information in case of pdf.
opts[:outfile] =~ /pdf$/ ?  added_opts = "--pdf-engine=xelatex --template=#{metadata["template"]} " : added_opts = ""

pandoc_cmd = "pandoc -sr markdown+yaml_metadata_block+citations \
  #{added_opts} \
  --filter pandoc-citeproc \
  #{opts[:metadata_file]} #{files} \
  -o #{opts[:outfile]}" 
system pandoc_cmd

