require 'thread'

class CleanThread

  class ThreadFinish < Exception
    # NB: Most exceptions should inherit from StandardError, but this is deliberate.
  end

  # If the current thread was invoked by CleanThread, invoke
  # CleanThread#check_finishing.
  def self.check_finishing
    ct = Thread.current[:clean_thread]
    return nil if ct.nil?
    ct.check_finishing
  end

  # If the current thread was invoked by CleanThread, return the result of
  # CleanThread#finishing?.  Otherwise, return nil.
  def self.finishing?
    ct = Thread.current[:clean_thread]
    return nil if ct.nil?
    return ct.finishing?
  end

  # Initialize a new CleanThread object.
  #
  # If a block is given, that block will be executed in a new thread when the
  # start method is called.  If no block is given, the main method will be used.
  #
  # The block is passed the CleanThread instance it belongs to, plus any
  # arguments passed to the new method.
  def initialize(*args, &block)
    @_cleanthread_mutex = Mutex.new
    @_cleanthread_stopping = false  # locked by _cleanthread_mutex
    @_cleanthread_thread = nil  # locked by _cleanthread_mutex.  Once set, it is not changed.
    @_cleanthread_proc = block
    @_cleanthread_args = args
  end

  # Start the thread.
  def start
    @_cleanthread_mutex.synchronize {
      if @_cleanthread_thread.nil?
        @_cleanthread_thread = Thread.new do
          begin
            # Set the Java thread name (for debugging)
            Java::java.lang.Thread.current_thread.name = "#{self.class.name}-#{self.object_id}" if defined?(Java)

            # Set the CleanThread instance (for use with the CleanThread.check_finishing
            # and CleanThread.finishing? class methods
            Thread.current[:clean_thread] = self

            if @_cleanthread_proc.nil?
              main(*@_cleanthread_args)
            else
              @_cleanthread_proc.call(self, *@_cleanthread_args)
            end
          rescue ThreadFinish
            # Do nothing - exit cleanly
          rescue Exception, ScriptError, SystemStackError, SyntaxError, StandardError => exc
            # NOTE: rescue Exception should be enough here, but JRuby seems to miss some exceptions if you do that.
            #
            # Output backtrace, since otherwise we won't see anything until the main thread joins this thread.
            display_exception(exc)
            raise
          ensure
            # This is needed.  Otherwise, the database connections aren't returned to the pool and things break.
            ActiveRecord::Base.connection_handler.clear_active_connections! if defined? ActiveRecord::Base
          end
        end
      else
        raise TypeError.new("Thread already started")
      end
    }
    return nil
  end

  # Ask the thread to finish, and wait for the thread to stop.
  #
  # If the :nowait option is true, then just ask the thread to finish without
  # waiting for it to stop.
  #
  # When a thread invokes its own finish method, ThreadFinish is raised,
  # unless :nowait is true.
  def finish(options={})
    @_cleanthread_mutex.synchronize {
      raise RuntimeError.new("not started") if @_cleanthread_thread.nil?
      @_cleanthread_stopping = true
    }
    unless options[:nowait]
      raise ThreadFinish if @_cleanthread_thread == ::Thread.current
      @_cleanthread_thread.join
    end
    return nil
  end

  # Return true if the thread is alive.
  def alive?
    @_cleanthread_thread && @_cleanthread_thread.alive?
  end

  # Wait for the thread to stop.
  def join
    return @_cleanthread_thread.join
  end

  # Return true if the finish method has been called.
  def finishing?
    @_cleanthread_mutex.synchronize { return @_cleanthread_stopping }
  end

  # Exit the thread if the finish method has been called.
  #
  # Functionally equivalent to:
  #  raise ThreadFinish if finishing?
  def check_finishing
    raise ThreadFinish if finishing?
    return nil
  end

  protected
  # Override this method if you want this thread to do something.
  def main(cleanthread)
    # default is to do nothing
  end

  # Override this method if you want the stacktrace output to happen differently
  def display_exception(exception)
    lines = []
    lines << "#{exception.class.name}: #{exception.message}\n"
    lines += exception.backtrace.map{|line| "\tfrom #{line}"}
    $stderr.puts lines.join("\n")
  end
end
