import { NextResponse } from 'next/server';

export function middleware(request) {
  const { pathname } = request.nextUrl;

  // Public routes
  const publicRoutes = [
    '/',
    '/about',
    '/contact',
    '/api/health',
    '/api/health/all',
    '/api/system/stats',
    '/favicon.ico',
    '/robots.txt',
  ];

  // Allow public routes to proceed
  if (publicRoutes.some(route => pathname === route || pathname.startsWith(route + '/'))) {
    return NextResponse.next();
  }

  // Auth check (example: cookie named 'auth-token')
  const authToken = request.cookies.get('auth-token')?.value;
  if (!authToken || authToken.length < 10) {
    // Redirect unauthenticated users to login page
    const loginUrl = new URL('/login', request.url);
    loginUrl.searchParams.set('redirect', pathname);
    return NextResponse.redirect(loginUrl);
  }

  // Allow authenticated requests
  return NextResponse.next();
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico|robots.txt).*)'],
};
