if test ! -e dagger.json
  echo "Dagger.json not found..."
  return 1
end
if test ! -e ./sdk
  echo "Generated SDK (./sdk) not found..."
  return 1
end
venv
python -m pip install -e ./sdk
