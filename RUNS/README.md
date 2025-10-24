    # Run Options (quick starts)

    These scripts and commands cover common, logical flows. Edit inventory and vars first.

    ## Run everything (site.yml)
    ```bash
    ansible-playbook site.yml
    ```

    ## Environment stack
    ```bash
    ansible-playbook playbooks/run_environment.yml
    ```

    ## Monitoring stack
    ```bash
    ansible-playbook playbooks/run_monitoring.yml
    ```

    ## CI (Jenkins on router)
    ```bash
    ansible-playbook playbooks/run_ci.yml
    ```

    ## News pipeline
    ```bash
    ansible-playbook playbooks/run_news.yml
    ```

    ## Sentiments pipeline
    ```bash
    ansible-playbook playbooks/run_sentiments.yml
    ```

    ## One-off role runners
    - `ansible-playbook playbooks/run_role_check-influxdb.yml`
- `ansible-playbook playbooks/run_role_create-grafana-token.yml`
- `ansible-playbook playbooks/run_role_deploy-jenkins.yml` 

    ## Common flags
    - Limit hosts: `-l k3s2`
    - Dry run: `--check`
    - Verbose: `-vvv`
    - Show diffs: `--diff`
    - Extra vars: `-e 'KEY=value'` or `-e @file.yml`
    - Start at task: `--start-at-task 'Task Name'`
