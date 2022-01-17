# crossPatchByGroup-GMA2
Inverser le patch de 2 groupes dans GrandMA2
v1.1

## Utilisation :
CrossPatchByGroup permet d'inverser le patch de 2 groupes.
On peut alors rattraper le patch de machines qui seraient adressée dans le mauvais ordre.
Ou alors inverser 2 LX qui ont été inversé.

Pour fonctionner CPBG a besoin de 2 groupes, A et B.

Dans le cas ou les machines dans les groupes A et B ne sont pas les mêmes (pour inverser le patch de 2 LX par exemple), il n'y a pas de priorité à prendre en compte. Il suffit de faire ses 2 groupes dans le bon ordre, de lancer le plugin, lui donner les numéros des 2 groupes puis de valider.

Dans le cas ou le but est de refaire l'ordre du patch, il faut faire un groupe avec l'ordre finale voulu (par exemple Fixture ID 101 Thru 108), il sera le groupe A. Puis un deuxième groupe avec l'ordre actuel réel des machines qui sera le groupe B et enfin lancer le plugin.

Lors de la demande de confirmation de crosspatch, une grande vue sur la command line est recommandée pour voir l'aperçu des changements que va effectuer le crosspatch.

## QuickPatch !
QuickPatch est un outil qui permet d'inverser rapidement le patch entre 2 fixture.
Pour l'utiliser il suffit de sélectrionner les machines que vous souhaitez inverser, puis dans lancer le plugin.