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
