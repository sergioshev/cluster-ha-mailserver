# Define el intervalo durante el cual la tupla se considera "firme"
# Este valor representa dias

 $TRUST = "40 days";

# Define el intervalo durante el cual se va mantener abierta la ventana blaca
# Este valor representa dias.

 $OPEN = "5 days";

# Define el intervalo durante el cual se ignoran las actulizaciones
# del contador "tiempo de carencia"
# Este valor representa horas

 $LACK = "2 hours";

# Define el la porcion del tiempo de confiaza a partir del cual
# se abre la "ventana gris" para una recalulo automatico
#
# Este valor representa la proporcion, valor real entre 0 y 1
# pero este se almacenara como un numero ente 0 y 100, al recuperarse
# se dividira por 100

 $COEF = "50";

# Define el numero de recepciones que debe ocurrir en la ventana blanca
# para convertirse en valido un remitente
#
# Este valor representa un entero

 $COUNT = "3";

