function venv
  if test ! -e .venv/bin/activate.fish
    echo "Error: Activation script not found."
    return 1
  end
  source .venv/bin/activate.fish
  python -m pip install --upgrade pip
  return 0
end
