**Parallel::ForkManager**
=========================
```diff
+ a simple and powerful module that can be used to perform a series of operations in parallel within a single Perl script
+ well-suited to performing a number of repetitive operations on a relatively powerful machine
```
```perl
#  instantiate the Parallel::ForkManager object with a number representing the maximum number of processes to fork
my $manager = new Parallel::ForkManager( 20 );
```
+ After instantiating a Parallel::ForkManager object, you can start forking processes using the start method. It is important to also define the point at which the child processes will finish. This is usually performed within a for or while loop, so the syntax will look like this:
```perl
foreach my $command (@commands) {
	# starts running the command via a forked process and advances to the next command in the @command array
	# The start method takes an optional parameter named $process_identifier, which can be used in callbacks
	$manager->start and next;
	system( $command );
	$manager->finish;
};
```

**call back**
--------------
wait_all_children: performs a blocking wait on the parent program that waits until all forked processes have finished  
run_on_start - run when each process is started  
run_on_finish - run when each process is finished  
run_on_wait - run when a process needs to wait for startup  
```perl
$manager->run_on_start( 
	sub {
		my ($pid,$ident) = @_;
		print "Starting processes $ident under process id $pid\n";
	}
);
```
**The arguments passed to the run_on_start sub are the process id of the forked process (provided by the operating system) and an identifier for the process that can be defined in the start method of the Parallel::ForkManager process.**  
**You should remember this in case that you don't provide an identifier in the call to start, this will make $ident be undefined and cause the Perl interpreter to complain (if you are using strict and warnings).**  
