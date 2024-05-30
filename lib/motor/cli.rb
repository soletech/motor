# frozen_string_literal: true

require "optparse"

require "motor"

module Motor
  module CLI
    PROGNAME = "rotor"
    CLIError = Class.new(Error)
    HANDLER  = {
      read:  {
        "json": Reader::JSON,
        "xlsx": Reader::XLSX
      },
      write: {
        "json": Writer::JSON,
        "xlsx": Writer::XLSX
      }
    }.freeze

    Options = Struct.new(:read, :write, :help, :version)

    class << self
      def call(argv)
        arguments(parser = options(argv, options = Options.new), argv)

        infile, outfile = argv

        config(infile, outfile, options)
        run(infile, outfile, options)
      rescue CLIError => e # rubocop:disable Lint/RescueException
        warn(parser.help)
        warn("")
        abort(e.message)
      end

      private

      # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      def options(argv, options)
        Signal.trap("INT") { Kernel.abort("") }

        OptionParser.new do |option| # rubocop:disable Metrics/BlockLength
          option.banner = <<~BANNER
            Usage: #{PROGNAME} [options...] <INFILE> [<OUTFILE>]

            Options:

          BANNER

          option.on("-r", "--read TYPE", "Read type: json, xslx, default: json", String) do |opt|
            options.read = reader!(opt)
          end

          option.on("-w", "--write TYPE", "Write type: json, xslx, default: json", String) do |opt|
            options.write = writer!(opt)
          end

          option.on_tail("-h", "--help", "Show this message") do
            abort(option.help)
          end

          option.on_tail("-v", "--version", "Show version") do
            warn(VERSION)
            exit
          end
        end.tap { |parser| parser.parse!(argv) } # rubocop:disable Style/MultilineBlockChain
      end
      # rubocop:enable Metrics/MethodLength,Metrics/AbcSize

      def arguments(parser, argv)
        raise(CLIError, "Too many arguments.") if argv.size > 2
      end

      def reader!(type)
        HANDLER[:read][type.downcase.to_sym].tap do |handler|
          raise(CLIError, "Unsupported reader type: #{type}") unless handler
        end
      end

      def writer!(type)
        HANDLER[:write][type.downcase.to_sym].tap do |handler|
          raise(CLIError, "Unsupported writer type: #{type}") unless handler
        end
      end

      # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      def config(infile, outfile, options)
        raise(CLIError, "No input file given.") unless infile
        raise("No such file: #{infile}") unless ::File.exist?(infile)

        return if options.read && options.write

        options.read  = reader!(::File.extname(infile)[1..]) unless options.read

        raise(CLIError, "No output file specified for XLSX") if options.write && !outfile

        options.write = writer!(outfile ? ::File.extname(outfile)[1..] : "json") unless options.write

        raise(CLIError, "Missing read type")  unless options.read
        raise(CLIError, "Missing write type") unless options.write
      end
      # rubocop:enable Metrics/MethodLength,Metrics/AbcSize

      def run(infile, outfile, options)
        input   = options.read.new(infile)
        problem = Model::Problem.create(input)
        output  = options.write.(problem)

        if outfile
          ::File.write(outfile, output)
        else
          puts(output)
        end
      end
    end
  end
end
