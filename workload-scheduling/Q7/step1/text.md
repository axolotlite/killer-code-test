**PriorityClass**

### Tasks

1. **Create a new PriorityClass** named `high-priority`
    * The **value** must be exactly **one less** than the highest existing user-defined PriorityClass.  
    * This PriorityClass is for **user workloads**, not system workloads.  
2. **Update the `busybox-logger` deployment** in the `priority` namespace to use this `high-priority` PriorityClass.  

**Hint:** Check the `~/validation.log` file after each check to see what is wrong with your answer.