import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import Button from './Button';

describe('Button Component', () => {
  test('rend le bouton avec le texte correct', () => {
    render(<Button>Cliquez-moi</Button>);
    expect(screen.getByText('Cliquez-moi')).toBeInTheDocument();
  });

  test('appelle onClick quand cliqué', () => {
    const handleClick = jest.fn();
    render(<Button onClick={handleClick}>Cliquez-moi</Button>);
    
    fireEvent.click(screen.getByText('Cliquez-moi'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  test('est désactivé quand disabled est true', () => {
    render(<Button disabled>Cliquez-moi</Button>);
    expect(screen.getByText('Cliquez-moi')).toBeDisabled();
  });
});
