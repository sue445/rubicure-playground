# rubicure-playground
## Development
```bash
bundle install
```

```bash
bundle exec puma -C config/puma.rb
# open http://localhost:8080/play
```

or 

```bash
bundle exec rackup
# open http://localhost:9292/play
```

or

```bash
docker compose up --build
# open http://localhost:8080/play
```
