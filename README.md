# Lost and Found

A small website where people can post things they found, post things they lost, and look through what others have posted.

- People can post a **found item** or a **lost item**, with an optional photo.
- Every new post waits for an admin to approve it before anyone else can see it.
- Visitors can search by words and filter by category.
- Visitors can send the team a message from the Contact tab.
- Admins sign in at `/admin.html` to approve posts, mark them as claimed, and read messages.

It is plain HTML and JavaScript. There is no framework and nothing to install to run the pages. [Supabase](https://supabase.com) stores the data, handles admin sign-in, and keeps the photos. [GitHub Pages](https://pages.github.com) hosts the site.

## What is in this folder

| Path | What it does |
| --- | --- |
| `public/index.html` | The main site that visitors use |
| `public/admin.html` | The admin page |
| `public/styles.css` | Looks and layout |
| `supabase/schema.sql` | Sets up the database tables, rules and photo storage |
| `.github/workflows/deploy.yml` | Puts the site online on GitHub Pages and writes `public/config.js` from your secrets |

## Set it up

### Step 1: Supabase

1. Make a new project at supabase.com.
2. Open **SQL Editor**, paste in everything from `supabase/schema.sql`, and run it.
3. Go to **Authentication > Users** and add a user with an email and password. Tick "Auto confirm". Copy the user's ID.
4. Back in **SQL Editor**, run this with your ID in place of `<ID>`:

   ```sql
   insert into admins (user_id, role) values ('<ID>', 'admin');
   ```

   Use `'staff'` instead of `'admin'` for people who may handle posts and messages but should not change categories.
5. Go to **Authentication > Sign In / Providers** and turn off "Allow new users to sign up". This way only people you add can sign in.
6. Go to **Project Settings > API** and copy the **Project URL** and the **anon public** key.

### Step 2: Put the code on GitHub

Create a new empty repository on GitHub, then run these in this folder:

```bash
git remote add origin https://github.com/YOUR-NAME/YOUR-REPO.git
git branch -M main
git push -u origin main
```

### Step 3: Turn on GitHub Pages

1. In your repository open **Settings > Pages** and set **Source** to **GitHub Actions**.
2. Open **Settings > Secrets and variables > Actions** and add two repository secrets:
   - `SUPABASE_URL` with your Project URL
   - `SUPABASE_ANON_KEY` with your anon public key
3. Open the **Actions** tab, pick **Deploy site**, and press **Run workflow**. After that it runs on its own each time you push to `main`.
4. Your site will be at `https://YOUR-NAME.github.io/YOUR-REPO/`. The admin page is at `/admin.html` on the same address.

## Try it on your own computer

1. Make a file called `public/config.js` with your own Supabase URL and anon key:

   ```js
   export const SUPABASE_URL = "https://your-project.supabase.co";
   export const SUPABASE_ANON_KEY = "your-anon-key";
   ```

2. Run:

   ```bash
   npx serve public
   ```

3. Open the address it prints.

`public/config.js` is listed in `.gitignore`, so your own settings are not uploaded to GitHub.

## How posts work

Found and lost posts live in the same `items` table. A lost post has `[LOST] ` at the start of its title. The site hides that start when it shows the post, and uses it to place the post on the Lost items board. Because of this, the database needs no extra columns for lost items.

## About keys

The anon key is meant to be public. The rules in `schema.sql` (Row Level Security) decide who can read and write what. Never put the `service_role` key anywhere in this project.
