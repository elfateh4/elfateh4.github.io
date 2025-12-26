# elfateh4.github.io

My Personal Blog - A simple, clean blog hosted on GitHub Pages with a black and white theme.

## How to Add New Blog Posts

This blog uses Markdown files for writing posts. To add a new blog post:

1. **Create a new markdown file** in the `posts/` directory (e.g., `posts/my-new-post.md`)

2. **Add frontmatter** at the top of your markdown file:
   ```markdown
   ---
   title: Your Post Title
   date: Month Day, Year
   ---
   ```

3. **Write your content** using standard Markdown syntax below the frontmatter:
   - Headers: `#`, `##`, `###`
   - Bold: `**text**`
   - Italic: `*text*`
   - Links: `[text](url)`
   - Lists: `- item` or `1. item`
   - Blockquotes: `> text`
   - Inline code: `` `code` ``

4. **Update index.html** to add your new post to the homepage:
   ```html
   <article class="blog-post">
       <h2><a href="posts/post.html?post=my-new-post.md">Your Post Title</a></h2>
       <p class="post-meta">Month Day, Year</p>
       <p>Brief description or excerpt...</p>
       <a href="posts/post.html?post=my-new-post.md" class="read-more">Read more →</a>
   </article>
   ```

5. **Commit and push** your changes to GitHub, and your post will be live!

## Local Development

To test your blog locally:

```bash
python3 -m http.server 8000
```

Then visit `http://localhost:8000` in your browser.

## Design Philosophy

This blog uses only black and white colors, focusing on:
- Clean typography
- Readable content
- Simple, distraction-free design
- Fast loading times

