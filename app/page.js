export default function Home() {
  const buildDate = Date.now();
  const formattedDate = new Intl.DateTimeFormat("en-US", {
    dateStyle: "long",
    timeStyle: "long",
  }).format(buildDate);
  return (
    <>
      <h1>Static page wow!</h1>
      <p>such static. It was built on {formattedDate}.</p>
      <p>
        <a href="/ssr">View a server-side rendered page.</a>
      </p>
    </>
  );
}