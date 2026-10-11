all:
	stow --verbose --ignore='\.tmp\..*' --target=$$HOME --restow .

delete:
	stow --verbose --ignore='\.tmp\..*' --target=$$HOME --delete .
