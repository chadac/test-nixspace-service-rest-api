{
  lib,
  python3,
  my-library,
}:
python3.pkgs.buildPythonPackage {
  pname = "my_rest_api";
  version = "0.0.1";

  src = lib.cleanSource ./.;
  pyproject = true;

  buildInputs = with python3.pkgs; [
    setuptools
    setuptools-scm
  ];

  propagatedBuildInputs = with python3.pkgs; [
    flask
    my-library
  ];
}
