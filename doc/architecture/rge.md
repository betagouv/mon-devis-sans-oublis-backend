# RGE via API ADEME

L'analyse du travail de validation des dossiers et des études a révélé que la conformité des certifications RGE et leur cohérence avec le SIRET indiqué dans le devis, selon la date des travaux, constituent un motif de vigilance.

Nous avons donc intégré l'API ADEME pour récupérer les certifications associées à une entreprise avec leurs périodes de validité et les gestes de travaux correspondants. Cela permet de retourner une erreur ou un avertissement en cas d'incohérence.

## Formulaire dédié

Cette vérification étant chronophage pour un humain, nous avons extrait la partie recherche de certification pour un ensemble SIRET - dates - gestes de travaux dans un formulaire dédié accessible en libre-service sur la plateforme.
