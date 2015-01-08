# mesos-slaves-attr

Example Vagrant VMs to run mesos-slaves with attributes.

# Content
    - A mesos MASTER with marathon enabled (master1/).
    - 3 mesos SLAVES (slave[1-3]/).

## How to run

- Master:

        cd master1/
        vagrant up

- Slave:

        cd slaveX/    # Where X is 1, 2 or 3
        vagrant up

Once the master and the slaves are up, you can go to: `http://33.33.33.100:5050`
to check the Mesos Web UI. Marathon will be running on `http://33.33.33.100:8080`

## Attributes

- slave1:

        role=platform
        zone-us-east-1

- slave2:

        role=scrapinghub
        zone-us-east-1

- slave3:

        role=platform
        zone-us-west-1


## Testing attributes

In order to check that attributes are being considered for tasks:

- Go to Marathon UI and add a new app. In the `Constraints` field add something
  like `zone:LIKE:us\-east\-1`, then the app should run only on slave1 and slave2.

- Add another app with the following contraint: `role:LIKE:platform`. This app
  should only run on slave1 and slave3.
