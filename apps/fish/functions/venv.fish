if test ! -e .venv/bin/activate.fish
  echo "Activation script not found."
  return 1
end
source .venv/bin/activate.fish
python -m pip install --upgrade pip
return 0
