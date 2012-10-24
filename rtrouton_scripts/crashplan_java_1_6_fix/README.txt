Following the release of Apple's Java for OS X 2012-006 update, Crashplan posted steps to allow the Crashplan backup engine to continue to use Java 6:

https://crashplan.zendesk.com/entries/22199717-apple-update-java-1-06-0-37-causes-crashplan-to-not-start-for-anyone-running-java-1-6-alongside-1-7

Mark Bolwell (@innermotion) sent me a copy of his script that automates the steps of the Crashplan fix:

A. Unloads the Crashplan LaunchDaemon
B. Sets the 0 string in the Program Arguments key to "/System/Library/Java/JavaVirtualMachines/1.6.0.jdk/Contents/Commands/java" (no quotes)
C. Reloads the Crashplan LaunchDaemon