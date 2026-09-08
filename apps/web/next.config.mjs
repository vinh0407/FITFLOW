/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    // Only bundled, content-hashed assets currently need image optimization.
    localPatterns: [{ pathname: '/_next/static/media/**' }],
    qualities: [75],
  },
  async headers() {
    return [
      {
        source: "/media/:path*",
        headers: [
          {
            key: "Cache-Control",
            value: "public, max-age=0, must-revalidate",
          },
        ],
      },
      {
        source: "/media-transparent/:path*",
        headers: [
          {
            key: "Cache-Control",
            value: "public, max-age=0, must-revalidate",
          },
        ],
      },
      {
        source: "/food/:path*",
        headers: [
          {
            key: "Cache-Control",
            value: "public, max-age=0, must-revalidate",
          },
        ],
      },
      {
        source: "/data/exercises-index.json",
        headers: [
          {
            key: "Cache-Control",
            value: "public, max-age=3600, stale-while-revalidate=86400",
          },
        ],
      },
    ];
  },
  async rewrites() {
    return [{ source: '/media/:path*', destination: '/media-transparent/:path*' }];
  }
};

export default nextConfig;
