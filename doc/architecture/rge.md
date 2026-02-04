# RGE via API ADEME

L'analyse du travail de validation des dossiers et des études a révélé que la conformité des certifications RGE et leur cohérence avec le SIRET indiqué dans le devis, selon la date des travaux, constituent un motif de vigilance.

Cette vérification étant chronophage pour un humain, nous avons extrait la partie recherche de certification pour un ensemble SIRET - dates - gestes de travaux dans un outil dédié accessible en libre-service via (formulaire web RGE)[https://mon-devis-sans-oublis.beta.gouv.fr/rge] ou (API RGE `/data_checks/rge`)[https://api.mon-devis-sans-oublis.beta.gouv.fr/api-docs/index.html#operations-Checks-checkRge].

Nous avons donc intégré l'API ADEME pour récupérer les certifications associées à une entreprise simplements via le SIRET et/ou une date et/ou directement le numéro RGE. Et de rendre les certifications associés avec leurs périodes de validité et les gestes de travaux correspondants. Cela permet de retourner une erreur ou un avertissement en cas d'incohérence.
