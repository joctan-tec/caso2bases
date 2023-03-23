import names
import pycountry
import random



    # insert into Clientes(
    # nombre,
    # apellido,
    # idPais,
    # fechaNacimiento,
    # email,
    # telefono,
    # enabled)

    # values(
    # getName(),
    # getLastName(),
    # getCountry(),
    # getDate(),
    # getEmail(),
    # getPhone(),
    # 1
    #      
    # )
def generaInsertsClientes(numInserts):
    for i in range(numInserts):
        nombre = getName()
        apellido = getLastName()
        print("insert into cliente(nombre,apellido,idPais,fechaNacimiento,email,telefono,enabled)"+
               " values("+
                "\""+nombre+"\","+
                "\""+apellido+"\","+str(random.randint(1, 250))+","+
                "\""+getDate()+"\","+"\""+getEmail(nombre, apellido)+"\","+
                "\""+getPhone()+"\","+"1"
                   +");"
            )

def getDate():
    return str(random.randint(1970, 2000)) + "-" + str(random.randint(1, 12)) + "-" + str(random.randint(1, 28))

def getName():
    return names.get_first_name()

def getLastName():
    return names.get_last_name()

def getCountry(num):
    return list(pycountry.countries)[num].name

def getEmail(nombre,apellido):
    
    if (len(nombre)<3):
        return (nombre+apellido+"@gmail.com").lower()
    return (nombre[0:4]+apellido+"@gmail.com").lower()

def getPhone():
    return str(random.randint(1000, 10000))+"-" + str(random.randint(1000, 10000))

def generaInsertsPaises(cantidad):
    for i in range(cantidad+1):
        print("insert into pais(nombre) values("+
            "\""+getCountry(i)+"\""+");")


def generaOperador(cantidad):
    for i in range(cantidad):
        print("insert into operador(nombre, apellido, enabled) values("+
            "\""+getName()+"\","+"\""+getLastName()+"\","+"1);")
#generaOperador(15)

generaInsertsClientes(10)

#generaInsertsPaises(248)