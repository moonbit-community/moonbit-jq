///|
/// Evaluate binary operation
fn eval_binary_op(
  op : BinaryOp,
  left : Json,
  right : Json,
) -> Json raise InterpreterError {
  match op {
    Add => json_add(left, right)
    Subtract => json_subtract(left, right)
    Multiply => json_multiply(left, right)
    Divide => json_divide(left, right)
    Modulo => json_modulo(left, right)
    Equal => Json::boolean(compare_json(left, right) == 0)
    NotEqual => Json::boolean(compare_json(left, right) != 0)
    LessThan => Json::boolean(compare_json(left, right) < 0)
    LessEq => Json::boolean(compare_json(left, right) <= 0)
    GreaterThan => Json::boolean(compare_json(left, right) > 0)
    GreaterEq => Json::boolean(compare_json(left, right) >= 0)
    And => {
      let left_truthy = match left {
        False | Null => false
        _ => true
      }
      if left_truthy {
        right
      } else {
        Json::boolean(false)
      }
    }
    Or => {
      let left_truthy = match left {
        False | Null => false
        _ => true
      }
      if left_truthy {
        left
      } else {
        right
      }
    }
  }
}

///|
/// Arithmetic operations
fn json_add(left : Json, right : Json) -> Json raise InterpreterError {
  match (left, right) {
    (Number(a, ..), Number(b, ..)) => Json::number(a + b)
    (String(a), String(b)) => Json::string(a + b)
    (Array(a), Array(b)) => Json::array(a + b)
    (Object(a), Object(b)) => {
      let result = a
      for k, v in b {
        result[k] = v
      }
      Json::object(result)
    }
    _ =>
      raise InvalidOperation(
        "Cannot add \{json_type_name(left)} and \{json_type_name(right)}",
      )
  }
}

///|
fn json_subtract(left : Json, right : Json) -> Json raise InterpreterError {
  match (left, right) {
    (Number(a, ..), Number(b, ..)) => Json::number(a - b)
    (Array(a), Array(b)) => {
      let result : Array[Json] = []
      for elem in a {
        let mut found = false
        for r in b {
          if compare_json(elem, r) == 0 {
            found = true
            break
          }
        }
        if not(found) {
          result.push(elem)
        }
      }
      Json::array(result)
    }
    _ =>
      raise InvalidOperation(
        "Cannot subtract \{json_type_name(right)} from \{json_type_name(left)}",
      )
  }
}

///|
fn json_multiply(left : Json, right : Json) -> Json raise InterpreterError {
  match (left, right) {
    (Number(a, ..), Number(b, ..)) => Json::number(a * b)
    (String(s), Number(n, ..)) | (Number(n, ..), String(s)) => {
      let count = n.to_int()
      let mut result = ""
      for _i = 0; _i < count; _i = _i + 1 {
        result = result + s
      }
      Json::string(result)
    }
    _ =>
      raise InvalidOperation(
        "Cannot multiply \{json_type_name(left)} and \{json_type_name(right)}",
      )
  }
}

///|
fn json_divide(left : Json, right : Json) -> Json raise InterpreterError {
  match (left, right) {
    (Number(a, ..), Number(b, ..)) => {
      if b == 0.0 {
        raise DivisionByZero
      }
      Json::number(a / b)
    }
    _ =>
      raise InvalidOperation(
        "Cannot divide \{json_type_name(left)} by \{json_type_name(right)}",
      )
  }
}

///|
fn json_modulo(left : Json, right : Json) -> Json raise InterpreterError {
  match (left, right) {
    (Number(a, ..), Number(b, ..)) => {
      if b == 0.0 {
        raise DivisionByZero
      }
      Json::number(a % b)
    }
    _ =>
      raise InvalidOperation(
        "Cannot modulo \{json_type_name(left)} by \{json_type_name(right)}",
      )
  }
}
