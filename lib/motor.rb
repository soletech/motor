# frozen_string_literal: true

require "json"
require "open3"
require "tempfile"

module Motor
  MOTOR = File.expand_path(File.join(__dir__, "..", "bin", "motor"))

  module Shell
    Result = Data.define(:args, :out, :err, :exit_code) do
      def cmd     = args.join(" ")

      def notok?  = !ok?

      def ok?     = exit_code&.zero?

      def outline = out.first

      def to_s    = out.join("\n")
    end

    # Adapted to popen3 from github.com/mina-deploy/mina
    class Runner
      def initialize
        @coathooks = 0
      end

      def run(*args, &block)
        out, err, status = Open3.popen3(*args) do |stdin, stdout, stderr, thread|
          inputs(stdin, thread, &block) if block
          outputs(stdout, stderr, thread)
        end

        Result[args, out, err, status.exitstatus]
      end

      private

      def inputs(stdin, thread, &block)
        stdin.instance_exec(thread, &block)
        stdin.close unless stdin.closed?
      end

      def outputs(stdout, stderr, thread)
        trap("INT") { handle_sigint(thread.pid) } # handle `^C`

        out = stdout.readlines.map(&:chomp)
        err = stderr.readlines.map(&:chomp)

        [out, err, thread.value]
      end

      def handle_sigint(pid)
        message, signal = if @coathooks > 1
          ["SIGINT received again. Force quitting...", "KILL"]
        else
          ["SIGINT received.", "TERM"]
        end

        warn("\n#{message}")
        ::Process.kill(signal, pid)
        @coathooks += 1
      rescue Errno::ESRCH
        warn("No process to kill.")
      end
    end

    extend self

    def run(...) = Runner.new.run(...)
  end

  extend self

  ValidationError = Class.new(StandardError)

  def validate(request)
    json = JSON.parse(request)

    validate_chunk(json["name"], ::String, "name")

    variables = validate_chunk(json["variables"], ::Array, "variables")
    variables_size = variables.size

    objective = validate_chunk(json["objective"], ::Hash, "objective")
    validate_chunk(objective["name"], ::String, "objective name")

    validate_chunk(objective["coefficients"], ::Array, "objective coefficients")

    inconsistencies = []

    validate_chunk(json["constraints"], ::Array, "constraints").each_with_index do |constraint, i|
      name = validate_chunk(constraint["name"], ::String, "constraints[#{i}] name")
      constraint_coefficients = validate_chunk(constraint["coefficients"], ::Array, "constraint '#{name}' coefficients")

      constraint_coefficients.each { |c| raise ValidationError, name.to_s unless c.is_a?(::Numeric) }

      next if (size = constraint_coefficients.size) == variables_size

      inconsistencies << { name:, size: }
    end

    raise ValidationError, inconsistencies unless inconsistencies.empty?
  end

  Response = Data.define(:json, :shell)

  def response(request)
    validate(request)
    call(request)
  end

  private

  def call(request)
    response = Tempfile.new("motor.json")
    result = Shell.run(MOTOR, "/dev/stdin", response.path) { puts request }
    Response.new(json: response.read, shell: result)
  ensure
    response.close
    response.unlink
  end

  def validate_chunk(data, type, context)
    raise ValidationError, "Required data not found: #{context}" if data.nil?
    raise ValidationError, "Data expected to be #{type}: #{context}" unless data.is_a?(type)

    data
  end
end
