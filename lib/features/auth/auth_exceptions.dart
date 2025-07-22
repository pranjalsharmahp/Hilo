//login Exception
class UserNotFoundAuthException implements Exception {}

class InvalidCredentialsAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}
//register exception

class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

//generic exception

class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}
