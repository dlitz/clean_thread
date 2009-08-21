require 'thread'

module HospitalPortal

  # Support for threads that exit cleanly.
  #
  # You may either subclass this class and override its main() method, or pass
  # a block to CleanThread.new.
  #
  # The code invoked by CleanThread should check periodically whether the
  # thread needs to exit, either by invoking the check_finishing method (which
  # raises ThreadFinish if the finish method has been called), or by manually
  # checking the result of the finishing? method and exiting if it returns true.
  #
  # = Examples
  #
  # == Overriding CleanThread#main
  #
  #   class MyThread < CleanThread
  #     def main
  #       loop do
  #         check_finishing
  #         # ... do some steps
  #         check_finishing
  #         # ... do some more steps
  #         check_finishing
  #         # ... do yet more steps
  #       end
  #     end
  #   end
  #
  #   t = MyThread.new
  #   t.start
  #   # ...
  #   t.finish
  #
  # == Passing a block to new
  #
  #   t = CleanThread.new do |t|
  #     loop do
  #       t.check_finishing
  #       # ... do some steps
  #       t.check_finishing
  #       # ... do some more steps
  #       t.check_finishing
  #       # ... do yet more steps
  #     end
  #   end
  #
  #   t.start   # Start the thread
  #   # ...
  #   t.finish  # Stop the thread

  class CleanThread

    class ThreadFinish < Exception
      # NB: Most exceptions should inherit from StandardError, but this is deliberate.
    end

    # Initialize a new CleanThread object.
    #
    # If a block is given, that block will be executed in a new thread when the
    # start method is called.  If no block is given, the main method will be used.
    #
    # The block is passed the CleanThread instance it belongs to, plus any
    # arguments passed to the new method.
    def initialize(*args, &block)
      @cleanthread_mutex = Mutex.new
      @cleanthread_stopping = false  # locked by cleanthread_mutex
      @cleanthread_thread = nil  # locked by cleanthread_mutex.  Once set, it is not changed.
      @cleanthread_proc = block
      @cleanthread_args = args
    end

    # Start the thread.
    def start
      @cleanthread_mutex.synchronize {
        if @thread.nil?
          @thread = Thread.new do
            begin
              if @cleanthread_proc.nil?
                main(*@cleanthread_args)
              else
                @cleanthread_proc.call(self, *@cleanthread_args)
              end
            rescue ThreadFinish
              # Do nothing - exit cleanly
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
    def finish(options={})
      @cleanthread_mutex.synchronize {
        raise RuntimeError.new("not started") if @thread.nil?
        @cleanthread_stopping = true
      }
      raise ThreadFinish if @thread == ::Thread.current
      @thread.join unless options[:nowait]
      return nil
    end

    # Return true if the thread is alive.
    def alive?
      return @thread.alive?
    end

    # Wait for the thread to stop.
    def join
      return @thread.join
    end

    # Return true if the finish method has been called.
    def finishing?
      @cleanthread_mutex.synchronize { return @cleanthread_stopping }
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

  end
end
