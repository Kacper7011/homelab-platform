# Monitoring Stack

Minimalny stack monitorujący oparty na Grafana + Prometheus + Loki.

## Struktura katalogów

```
monitoring/
├── docker-compose.yml
├── .env                        # NIE commituj do gita!
├── .env.example                # Szablon zmiennych środowiskowych
├── prometheus/
│   └── prometheus.yml          # Konfiguracja scrape'owania
├── loki/
│   └── loki.yml                # Konfiguracja Loki
└── grafana/
    └── provisioning/
        ├── datasources/
        │   └── datasources.yml # Automatyczne dodanie Prometheus i Loki
        └── dashboards/
            └── dashboards.yml  # Loader dla plików .json z dashboardami
```

Dane trwałe zapisywane są na hoście:
```
/mnt/monitoring/
├── prometheus/   # Dane TSDB Prometheusa (30-dniowa retencja)
└── loki/         # Chunki i indeksy Loki
```

## Pierwsze uruchomienie

```bash
# 1. Utwórz katalogi na dane
sudo mkdir -p /mnt/monitoring/prometheus /mnt/monitoring/loki

# 2. Skonfiguruj zmienne środowiskowe
cp .env.example .env
nano .env   # zmień hasło Grafany!

# 3. Uruchom stack
docker compose up -d

# 4. Sprawdź logi
docker compose logs -f
```

## Dostęp

| Usługa     | Adres                  | Login         |
|------------|------------------------|---------------|
| Grafana    | http://localhost:3000  | z pliku .env  |
| Prometheus | http://localhost:9090  | —             |
| Loki       | http://localhost:3100  | —             |

## Zatrzymanie i czyszczenie

```bash
# Zatrzymaj stack
docker compose down

# Zatrzymaj i usuń wolumeny Grafany (dane Prometheus/Loki zostają na /mnt)
docker compose down -v
```

## Rozbudowa stacku

### Dodanie nowego targetu do Prometheusa
Edytuj `prometheus/prometheus.yml` i dodaj wpis w `scrape_configs`.

### Dodanie dashboardu
Wrzuć plik `.json` (eksport z Grafany) do katalogu `grafana/provisioning/dashboards/`.
Dashboard załaduje się automatycznie po restarcie lub w ciągu 30 sekund.

### Dodanie agenta logów (Promtail / Alloy)
Utwórz katalog `agents/promtail/` lub `agents/alloy/`, dodaj konfigurację
i dopisz serwis do `docker-compose.yml`.
