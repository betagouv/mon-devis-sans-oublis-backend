# Système de mail entrant et sortant

# Envoi (sortant)

Ils sont envoyés de manière asynchrone via le service Brevo.

- [Mail previews](http://localhost:3000/rails/mailers/)

## Entrant pour vérifier un devis ou un dossier

Pour simplifier l'usage du service, nous permettons aux usagers de nous envoyer un ou plusieurs mails sur une adresse email spécifique. Nous recevons les mails entrants via les webhooks Brevo configurés et implémentés.

Nous traitons le devis ou le dossier comme s'il avait été déposé sur l'interface, puis nous renvoyons les résultats par email au format HTML.

## Vérifier un devis via email

En mode local `development` :

Accédez à http://localhost:3000/rails/conductor/action_mailbox/inbound_emails pour suivre les mails entrants.

Pour les autres environnements `staging` et `production` :

- suivez la [documentation Inbound Parsing Brevo](https://developers.brevo.com/docs/inbound-parse-webhooks)
- configurez les variables d'environnement `BREVO*` et `RAILS_INBOUND*`
- lancez l'upsert du webhook via `rake brevo:setup_webhook`, car celui-ci n'est faisable que via l'API Brevo et ⚠️ reste invisible sur l'interface même une fois configuré
- testez et utilisez
