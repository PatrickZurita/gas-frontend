Vamos a crear un app con flutter que va a consumir un backend en python. Te voy a dejar todos los detalles de la aplicacion y del backend que tengo actualmente.

# 🚚 Gas Backend & Mobile App (MVP)

## 1. Descripción general del proyecto

Este proyecto consiste en una **app móvil con backend propio** para un negocio real de
**distribución de balones de gas** que opera en el distrito de **La Molina (Perú)**.

El objetivo principal es **reemplazar el registro manual en cuadernos físicos**
por un sistema digital **rápido, simple y confiable**, pensado para un **usuario mayor
de 50 años** que registra los pedidos **en el momento de la entrega**, directamente
desde su celular.

La aplicación no está pensada como un sistema administrativo complejo,
sino como una **herramienta operativa diaria**, enfocada en **reducir errores humanos**
y **mejorar el control del negocio**.

---

## 2. Problema real que se quiere resolver

Actualmente, el negocio registra los pedidos en hojas sueltas o cuadernos, donde se anota:

- Dirección del cliente
- Fecha del pedido
- Monto pagado
- Si el cliente debe o no

Este método genera problemas reales como:

- ❌ Pedidos que se olvidan de anotar  
- ❌ Letras ilegibles o confusión al revisar días pasados  
- ❌ Descuadres de stock  
  (ej. el cuaderno dice que se vendieron 10 balones, pero físicamente hay 9)
- ❌ Dificultad para saber cuándo un cliente suele volver a pedir
- ❌ Imposibilidad de analizar zonas con mayor o menor demanda

El sistema busca atacar estos problemas **desde la raíz**, facilitando el
**registro inmediato y confiable**.

---

## 3. Objetivo del MVP (fase actual)

En esta primera fase, el objetivo es **operativo**, no analítico:

- ✅ Registrar pedidos de forma rápida y simple
- ✅ Reducir la posibilidad de pedidos no registrados
- ✅ Permitir búsqueda de clientes tipo *contactos del celular*
- ✅ Registrar pagos y deudas reales (entregado pero no pagado)
- ✅ Consultar historial de pedidos por cliente

El éxito del MVP se mide con una sola pregunta:

> **¿El negocio dejó de depender del cuaderno?**

---

## 4. Enfoque de usuario (UX real)

El usuario final:

- Tiene más de 50 años
- Usa principalmente el celular
- Registra pedidos mientras trabaja en la calle
- Guarda clientes como contactos con la dirección como nombre

Por eso, la app debe:

- Tener pocos campos
- Evitar escritura innecesaria
- Usar autocompletado por dirección o teléfono
- Registrar pedidos en pocos toques
- Asignar valores por defecto (fecha = hoy)

---

## 5. Modelo de negocio reflejado en el sistema

### Cliente
- El cliente se identifica por un **alias**, normalmente la dirección  
  (ej. *“Las Higueras 371”*)
- Puede tener teléfono
- No se fuerza normalización estricta en el MVP

### Pedido
Cada pedido registra:

- Cliente
- Fecha del pedido (automática por defecto)
- Cantidad de balones
- Total en soles
- Si fue pagado o no
- Saldo pendiente (cuando hay deuda)

Esto refleja exactamente cómo funciona el negocio en la vida real:
El gas se entrega aunque el cliente no pague en el momento.

---

## 6. Problema adicional identificado: control de stock

El registro en papel provoca **descuadres entre el stock físico y los pedidos anotados**.

Aunque el MVP no implementa inventarios formales, el registro inmediato:

- Reduce errores
- Permite detectar inconsistencias
- Prepara el terreno para control de stock futuro

---

## 7. Arquitectura técnica (backend)

### Stack
- **Backend:** Python + FastAPI
- **Base de datos:** PostgreSQL
- **ORM:** SQLAlchemy
- **Migraciones:** Alembic

### Enfoque
- Backend minimalista orientado al flujo real
- Arquitectura *clean-ish / layered lite*
- Docker opcional (agnóstico al entorno)
- Preparado para análisis futuro

---

## 8. Endpoints principales del MVP

### Clientes
- POST /clientes
- GET /clientes/search?q=...
- GET /clientes/{id}

### Pedidos
- POST /pedidos
- GET /pedidos?cliente_id=...

Estos endpoints permiten construir el **frontend móvil completo del MVP**.

---

## 9. Uso de datos históricos

El negocio cuenta con pedidos antiguos registrados en papel.

Estos datos:

- Sí son valiosos
- Se migrarán a Excel
- Luego se cargarán de forma masiva al sistema

No se busca perfección, sino **histórico suficiente** para análisis.

---

## 10. Objetivos a futuro

Una vez consolidado el MVP:

- Análisis de recurrencia de pedidos
- Predicción de próximas compras
- Análisis geográfico por zonas
- Mapas de calor para marketing físico
- Control básico de stock
- Recordatorios automáticos

---

## 11. Principio rector del proyecto

> **Primero resolver el problema operativo real.  
> Luego usar los datos para inteligencia del negocio.**
AQUI ESTAN LOS ENDPOINTS QUE VAMOS A UTILIZR, SI TIENES ALGUN OBSERVACION EN BASE TU EXPERTISE EN MOBILE APPLICATIONS, UX UI EXPERIENCIE, HAZMELO SABER:

POST http://127.0.0.1:8000/clientes/
{
  "alias": "Santiago de chuco 287",
  "telefono": "985605284",
  "direccion": "Santiago de chuco 287"
}
{
  "id": 2,
  "alias": "Santiago de chuco 287",
  "telefono": "985605284"
}

GET http://127.0.0.1:8000/clientes/search?q=Higueras&limit=10
[
  {
    "id": 1,
    "alias": "Las Higueras 371",
    "telefono": "999888777"
  }
]

GET http://127.0.0.1:8000/clientes/1
{
  "id": 1,
  "alias": "Las Higueras 371",
  "telefono": "999888777"
}

POST http://127.0.0.1:8000/pedidos
{
  "cliente_id": 2,
  "cantidad_balones": 1,
  "total_soles": 55.00,
  "pagado": true
}
{
  "id": 3,
  "cliente_id": 2,
  "direccion_id": 2,
  "created_at": "2026-01-16T10:45:03.084894-05:00",
  "fecha_entrega": "2026-01-16",
  "cantidad_balones": 1,
  "total_soles": "55.00",
  "pagado": true,
  "saldo_pendiente": "0.00"
}

GET http://127.0.0.1:8000/pedidos?cliente_id=1
[
  {
    "id": 2,
    "cliente_id": 1,
    "direccion_id": 1,
    "created_at": "2026-01-16T10:33:46.613608-05:00",
    "fecha_entrega": "2026-01-16",
    "cantidad_balones": 2,
    "total_soles": "110.00",
    "pagado": true,
    "saldo_pendiente": "0.00"
  },
  {
    "id": 1,
    "cliente_id": 1,
    "direccion_id": 1,
    "created_at": "2026-01-16T10:31:29.676339-05:00",
    "fecha_entrega": "2026-01-16",
    "cantidad_balones": 2,
    "total_soles": "110.00",
    "pagado": true,
    "saldo_pendiente": "0.00"
  }
]
POST http://127.0.0.1:8000/clientes/
{
  "alias": "Tahuantinsuyo 207",
  "telefono": "985605284"
}

{
  "id": 3,
  "alias": "Tahuantinsuyo 207",
  "telefono": "985605284"
}

@router.post("/", response_model=ClienteOut, status_code=status.HTTP_201_CREATED)
def crear_cliente(payload: ClienteCreate, db: DbSession) -> ClienteOut:
    try:
        return repo.crear_cliente(
            db,
            alias=payload.alias.strip(),
            telefono=payload.telefono.strip(),
        )
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Ya existe un cliente con ese alias.",
        )


class ClienteCreate(BaseModel):
    alias: str = Field(min_length=3, max_length=120, description="Ej: Las Higueras 371")
    telefono: str = Field(min_length=6, max_length=30)

class ClienteOut(BaseModel):
    id: int
    alias: str
    telefono: str

    class Config:
        from_attributes = True


def crear_cliente(db: Session, alias: str, telefono: str) -> Cliente:
    cliente = Cliente(alias=alias, telefono=telefono, nombre=None)
    db.add(cliente)
    db.flush()
    
    dir1 = Direccion(
        cliente_id=cliente.id,
        texto_original=alias,
        distrito=None,
        referencia=None,
        activa=True,
    )
    db.add(dir1)

    db.commit()
    db.refresh(cliente)
    return cliente

ALIAS = DIRECCION, POR AHORA ESTA BIEN ASI.
PERO ME FALTA MOSTRARLO EN EL RESPONSE COMO LO MUESTRO?
Asi quedo:
POST http://127.0.0.1:8000/clientes/
{
  "alias": "Mandarinas 257",
  "telefono": "923777321"
}
{
  "id": 4,
  "alias": "Mandarinas 257",
  "telefono": "923777321",
  "direccion": "Mandarinas 257"
}

entonces ya podemos empezar a desarrollar el front?
Claro empecemos. En primer lugar necesito comandos para saber si mi computadora tiene instalado flutter y demas configuraciones necesarias. Por otro lado tambien me gustaria que me informes si en caso ya termino de desarrollar el app en mi local. Que pasos son los siguientes para que esta app pueda instalarlo en el celular del duenio del negocio (tiene un celular android), como desde su propio celular va a poder registrar pedidos y que se guarden en la base de datos (tendre que usar alguna plataforma como azure o aws? o hay alguna opcion mas barata para alojar mi backend). Cabe resaltar que al dia se registraran 10 - 20 pedidos. y pues hemos tratado de hacer el backend lo mas minimalista posible, asi que no creo que sea tan costoso mantenerlo en la nube. Tambien quiero saber si mi backend sera http o https porque una vez despliegue mi backend python en aws pero era http y no podia consumirlo desde una app web con react.  