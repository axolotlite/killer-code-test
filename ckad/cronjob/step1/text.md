**CronJob - Scheduling & Configuration**

### Tasks

1. **Create a CronJob** named `nameserver` with the following specifications:

   * **Container name:** `busybox`
   * **Image:** `busybox:stable`
   * **Command:**
     ```text
     grep -i nameserver /etc/resolv.conf
     ```{{copy}}

2. **Configure the CronJob schedule and limits:**

   * **Schedule:** Execute once every **30 minutes**
   * **Successful Jobs History Limit:** `50`
   * **Failed Jobs History Limit:** `100`

3. **Configure Pod lifecycle settings:**

   * **Restart Policy:** `Never`
   * **Active Deadline Seconds:** `8`

4. **Manually create a Job** called `nameserver-resolver` from the `nameserver` CronJob

**Hint:** Check the `~/validation.log` file after each check to see what is wrong with your answer.