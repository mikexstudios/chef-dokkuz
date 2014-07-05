# chef-dokku

Significant modifications.

## Notes

- Use `bundle exec` before all commands!

- To test:
  ```bash
  bundle exec kitchen create
  bundle exec kitchen converge
  bundle exec kitchen verify
  ```

- Don't use:
  ```bash
  bundle exec kitchen test
  ```
  since it destroys existing instance and repeats create, converge, verify for
  each time it is run.

