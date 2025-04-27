
# LOCAL DEVELOPMENT COMMANDS

create-airflow-db:
	mysql -u root -p$$MYSQL_ROOT_PASSWORD -e "DROP USER IF EXISTS 'airflow_user'@'%';"; \
	mysql -u root -p$$MYSQL_ROOT_PASSWORD -e "DROP USER IF EXISTS 'airflow_user'@'localhost';"; \
	mysql -u root -p$$MYSQL_ROOT_PASSWORD -e "DROP DATABASE IF EXISTS airflow_db;"; \
	mysql -u root -p$$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $$MYSQL_DATABASE CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"; \
	mysql -u root -p$$MYSQL_ROOT_PASSWORD -e "CREATE USER IF NOT EXISTS '$$MYSQL_USER'@'%' IDENTIFIED BY '$$MYSQL_PASSWORD';"; \
	mysql -u root -p$$MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON $$MYSQL_DATABASE.* TO '$$MYSQL_USER'@'%';"; \
	mysql -u root -p$$MYSQL_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"
	airflow db migrate

create-airflow-user:
	airflow users create \
  --username admin \
  --firstname Admin \
  --lastname User \
  --role Admin \
  --email admin@example.com \
  --password admin

generate-fernet-env:
	@FERNET_KEY=$$(python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"); \
	sed -i "s|^export AIRFLOW__CORE__FERNET_KEY=.*|export AIRFLOW__CORE__FERNET_KEY=$$FERNET_KEY|" .env;

generate-webserver-env:
	@WEBSERVER_KEY=$$(python3 -c "import secrets; print(secrets.token_hex(16))"); \
	sed -i "s|^export AIRFLOW__WEBSERVER__SECRET_KEY=.*|export AIRFLOW__WEBSERVER__SECRET_KEY=$$WEBSERVER_KEY|" .env;

generate-mysql-env:
	@MYSQL_KEY=$$(python3 -c "import secrets; print(secrets.token_hex(8))"); \
	sed -i "s|^export MYSQL_PASSWORD=.*|export MYSQL_PASSWORD=$$MYSQL_KEY|" .env;

set-up-envs:
	cp .env.example .env
	$(MAKE) generate-fernet-env
	$(MAKE) generate-webserver-env
	$(MAKE) generate-mysql-env


