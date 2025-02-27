import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import App from '../App';

describe('App Component', () => {
  test('renders learn react link', () => {
    render(<App />);
    const linkElement = screen.getByText(/learn react/i);
    expect(linkElement).toBeInTheDocument();
  });

  test('vérifie que le logo React est présent', () => {
    render(<App />);
    const logoElement = screen.getByAltText(/logo/i);
    expect(logoElement).toBeInTheDocument();
  });

  test('vérifie que le header est présent', () => {
    render(<App />);
    const headerElement = screen.getByRole('banner');
    expect(headerElement).toBeInTheDocument();
  });
});
