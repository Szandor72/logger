# An attempt at an Apex Logger Service for the Salesforce Lightning Platform

Leverages Platform Events to persist Log information  as 'Debug Entries' and uses `Custom Metadata Records` and `Custom Permissions` to configure what is logged for whom. Automatically detects current class and method name as well as current line and column.
If setup to trace classes only, will save only information from that class and ignore everything else.
Triggers logged with a pair of `Logger.logTrigger(Trigger.getOperationType)` (see below) will log each operation type seperately. E.g. AFTER_INSERT and BEFORE_INSERT will get two separate Debug Entries.

## Screenshots

[![DebugEntry Record View](https://i.imgur.com/00yymeb.png)](https://i.imgur.com/00yymeb.png)

[![Developer Console](https://i.imgur.com/PRtY1R6.png)](https://i.imgur.com/PRtY1R6.png)

## Usage Example

```java
/*
*   EXAMPLE CLASS FOR LOGGER
*/

public with sharing class Handler {
    public Handler() {
        Logger.push();
        routine1();
        routine2();
        Logger.pop();
    }

    public void routine1(){
        Logger.push();
        Logger.log('entering subroutine1');
        subroutine1();
        Logger.pop();
    }

    public void routine2(){
        Logger.push();
        subroutine2();
        Logger.pop();
    }

    public void subroutine1(){
        Logger.push();
        Logger.pop();
    }

    public void subroutine2(){
        Logger.push();
        subsub1();
        subsub2();
        Logger.pop();
    }

    public void subsub1(){
        Logger.push();
        Logger.log('doing complex stuff');
        subsub2();
        Logger.pop();
    }

    public void subsub2(){
        Logger.push();
        Logger.log('Doing stuff at stacktrace: ' + Logger.stackTrace);
        Logger.pop();
    }
}

/* Trigger Example */
trigger MocksTrigger on Mock__c (before insert, after insert) {
	Logger.logTrigger(Trigger.operationType);
    MocksService.validate(Trigger.new);
    Logger.logTrigger(Trigger.operationType);
}
```

## Kudos

[Dan Appleman](https://twitter.com/danappleman) and [Adrian Larsson](https://twitter.com/ApexLarson)
